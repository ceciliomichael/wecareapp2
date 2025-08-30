-- Create conversations table for messaging system
CREATE TABLE conversations (
    id VARCHAR(255) PRIMARY KEY,
    employer_id UUID NOT NULL REFERENCES employers(id) ON DELETE CASCADE,
    employer_name VARCHAR(255) NOT NULL,
    helper_id UUID NOT NULL REFERENCES helpers(id) ON DELETE CASCADE,
    helper_name VARCHAR(255) NOT NULL,
    job_id VARCHAR(255) NOT NULL, -- Can reference job_postings.id or helper_service_postings.id
    job_title VARCHAR(255) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'archived', 'blocked')),
    last_message_id VARCHAR(255),
    last_message_content TEXT,
    last_message_sender_id UUID,
    last_message_created_at TIMESTAMP WITH TIME ZONE,
    unread_count_employer INTEGER DEFAULT 0,
    unread_count_helper INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better performance
CREATE INDEX idx_conversations_employer_id ON conversations(employer_id);
CREATE INDEX idx_conversations_helper_id ON conversations(helper_id);
CREATE INDEX idx_conversations_job_id ON conversations(job_id);
CREATE INDEX idx_conversations_updated_at ON conversations(updated_at DESC);

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_conversations_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger to automatically update updated_at
CREATE TRIGGER update_conversations_updated_at
    BEFORE UPDATE ON conversations
    FOR EACH ROW
    EXECUTE FUNCTION update_conversations_updated_at();
