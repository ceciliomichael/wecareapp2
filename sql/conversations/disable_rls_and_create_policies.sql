-- Disable RLS for now (for development/testing)
ALTER TABLE conversations DISABLE ROW LEVEL SECURITY;

-- For production, you might want to enable RLS and create policies:
-- ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;

-- Example policies for production:
-- Allow users to see conversations they are part of
-- CREATE POLICY "Users can view their own conversations" ON conversations
--     FOR SELECT USING (
--         employer_id = auth.uid() OR helper_id = auth.uid()
--     );

-- Allow users to create conversations they are part of
-- CREATE POLICY "Users can create conversations" ON conversations
--     FOR INSERT WITH CHECK (
--         employer_id = auth.uid() OR helper_id = auth.uid()
--     );

-- Allow users to update conversations they are part of
-- CREATE POLICY "Users can update their own conversations" ON conversations
--     FOR UPDATE USING (
--         employer_id = auth.uid() OR helper_id = auth.uid()
--     );
