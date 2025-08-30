-- Disable RLS for now (for development/testing)
ALTER TABLE messages DISABLE ROW LEVEL SECURITY;

-- For production, you might want to enable RLS and create policies:
-- ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- Example policies for production:
-- Allow users to see messages from conversations they are part of
-- CREATE POLICY "Users can view messages from their conversations" ON messages
--     FOR SELECT USING (
--         conversation_id IN (
--             SELECT id FROM conversations 
--             WHERE employer_id = auth.uid() OR helper_id = auth.uid()
--         )
--     );

-- Allow users to send messages to conversations they are part of
-- CREATE POLICY "Users can send messages to their conversations" ON messages
--     FOR INSERT WITH CHECK (
--         conversation_id IN (
--             SELECT id FROM conversations 
--             WHERE employer_id = auth.uid() OR helper_id = auth.uid()
--         )
--         AND sender_id = auth.uid()
--     );

-- Allow users to update their own messages (for read status, etc.)
-- CREATE POLICY "Users can update messages in their conversations" ON messages
--     FOR UPDATE USING (
--         conversation_id IN (
--             SELECT id FROM conversations 
--             WHERE employer_id = auth.uid() OR helper_id = auth.uid()
--         )
--     );
