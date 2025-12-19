-- Add color column to teams table
ALTER TABLE public.teams ADD COLUMN color text DEFAULT '#3B82F6';

-- Create storage bucket for member photos
INSERT INTO storage.buckets (id, name, public) VALUES ('member-photos', 'member-photos', true);

-- Create policies for member photos bucket
CREATE POLICY "Anyone can view member photos" 
ON storage.objects 
FOR SELECT 
USING (bucket_id = 'member-photos');

CREATE POLICY "Authenticated users can upload member photos" 
ON storage.objects 
FOR INSERT 
WITH CHECK (bucket_id = 'member-photos' AND auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can update member photos" 
ON storage.objects 
FOR UPDATE 
USING (bucket_id = 'member-photos' AND auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can delete member photos" 
ON storage.objects 
FOR DELETE 
USING (bucket_id = 'member-photos' AND auth.role() = 'authenticated');