-- Create messages table for messaging system
CREATE TABLE messages (
    id VARCHAR(255) PRIMARY KEY,
    conversation_id VARCHAR(255) NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL,
    sender_type VARCHAR(20) NOT NULL CHECK (sender_type IN ('Employer', 'Helper')),
    sender_name VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    message_type VARCHAR(20) NOT NULL DEFAULT 'text' CHECK (message_type IN ('text', 'image', 'file', 'system')),
    status VARCHAR(20) NOT NULL DEFAULT 'sent' CHECK (status IN ('sending', 'sent', 'delivered', 'read', 'failed')),
    read_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better performance
CREATE INDEX idx_messages_conversation_id ON messages(conversation_id);
CREATE INDEX idx_messages_sender_id ON messages(sender_id);
CREATE INDEX idx_messages_created_at ON messages(created_at DESC);
CREATE INDEX idx_messages_status ON messages(status);

-- Create function to update conversation when message is inserted
CREATE OR REPLACE FUNCTION update_conversation_on_message()
RETURNS TRIGGER AS $$
BEGIN
    -- Update conversation with last message info
    UPDATE conversations 
    SET 
        last_message_id = NEW.id,
        last_message_content = NEW.content,
        last_message_sender_id = NEW.sender_id,
        last_message_created_at = NEW.created_at,
        unread_count_employer = CASE 
            WHEN NEW.sender_type = 'Helper' THEN unread_count_employer + 1 
            ELSE unread_count_employer 
        END,
        unread_count_helper = CASE 
            WHEN NEW.sender_type = 'Employer' THEN unread_count_helper + 1 
            ELSE unread_count_helper 
        END,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = NEW.conversation_id;
    
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger to automatically update conversation
CREATE TRIGGER update_conversation_on_message_insert
    AFTER INSERT ON messages
    FOR EACH ROW
    EXECUTE FUNCTION update_conversation_on_message();

-- Create function to mark messages as read
CREATE OR REPLACE FUNCTION mark_messages_as_read(
    conversation_id_param VARCHAR(255),
    user_id_param UUID,
    user_type_param VARCHAR(20)
)
RETURNS void AS $$
BEGIN
    -- Mark messages as read
    UPDATE messages 
    SET 
        status = 'read',
        read_at = CURRENT_TIMESTAMP
    WHERE 
        conversation_id = conversation_id_param 
        AND sender_id != user_id_param 
        AND status != 'read';
    
    -- Reset unread count for this user
    IF user_type_param = 'Employer' THEN
        UPDATE conversations 
        SET unread_count_employer = 0
        WHERE id = conversation_id_param;
    ELSE
        UPDATE conversations 
        SET unread_count_helper = 0
        WHERE id = conversation_id_param;
    END IF;
END;
$$ language 'plpgsql';
