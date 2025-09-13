-- Add location support to messages table
-- Migration to add location columns for live location sharing feature

-- Add location columns to messages table
ALTER TABLE messages 
ADD COLUMN latitude DECIMAL(10, 8),
ADD COLUMN longitude DECIMAL(11, 8),
ADD COLUMN address TEXT;

-- Update message_type enum to include location
ALTER TABLE messages 
DROP CONSTRAINT IF EXISTS messages_message_type_check;

ALTER TABLE messages 
ADD CONSTRAINT messages_message_type_check 
CHECK (message_type IN ('text', 'image', 'file', 'system', 'location'));

-- Create index for location queries
CREATE INDEX idx_messages_location ON messages(latitude, longitude) 
WHERE latitude IS NOT NULL AND longitude IS NOT NULL;

-- Create index for location message type
CREATE INDEX idx_messages_location_type ON messages(message_type) 
WHERE message_type = 'location';

-- Add comments for documentation
COMMENT ON COLUMN messages.latitude IS 'Latitude coordinate for location messages (WGS84)';
COMMENT ON COLUMN messages.longitude IS 'Longitude coordinate for location messages (WGS84)';
COMMENT ON COLUMN messages.address IS 'Human-readable address for location messages';

-- Update the trigger function to handle location messages
CREATE OR REPLACE FUNCTION update_conversation_on_message()
RETURNS TRIGGER AS $$
BEGIN
    -- For location messages, update content with location info for conversation preview
    IF NEW.message_type = 'location' AND NEW.address IS NOT NULL THEN
        NEW.content := '📍 ' || NEW.address;
    ELSIF NEW.message_type = 'location' THEN
        NEW.content := '📍 Location shared';
    END IF;

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

-- Example usage and validation
-- INSERT INTO messages (id, conversation_id, sender_id, sender_type, sender_name, content, message_type, latitude, longitude, address)
-- VALUES ('loc_001', 'test_conv_1', 'user_123', 'Employer', 'John Doe', 'Shared location', 'location', 9.6496, 123.8854, 'Tagbilaran City, Bohol, Philippines');
