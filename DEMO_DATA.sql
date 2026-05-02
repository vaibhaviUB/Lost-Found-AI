-- SQL Script to add demo items for presentation
-- Run this in Supabase SQL Editor to populate matches with 80% and 91% accuracy

-- Demo Lost Items
INSERT INTO lost_items (user_id, category, description, location, specific_location, color, brand, identifying_features, lost_date, latitude, longitude)
VALUES
  ('00000000-0000-0000-0000-000000000001', 'Electronics', 'Black Apple MacBook Pro 13 inch laptop with charging cable and mouse', 'Downtown', 'Near coffee shop', 'Silver', 'Apple', 'Apple logo, dent on corner', NOW() - INTERVAL '2 days', 40.7128, -74.0060),
  ('00000000-0000-0000-0000-000000000001', 'Accessories', 'Blue Sony WH-1000XM4 wireless headphones with case', 'University Campus', 'Student Center', 'Blue', 'Sony', 'Noise cancellation, scratch on left ear', NOW() - INTERVAL '1 day', 40.8075, -73.9626),
  ('00000000-0000-0000-0000-000000000001', 'Clothing', 'Red sports backpack with multiple pockets and water bottle holder', 'City Park', 'Picnic area near pond', 'Red', 'Nike', 'Nike swoosh, torn pocket inside', NOW() - INTERVAL '3 days', 40.7829, -73.9654);

-- Demo Found Items  
INSERT INTO found_items (user_id, category, description, location, specific_location, color, brand, found_date, latitude, longitude)
VALUES
  ('00000000-0000-0000-0000-000000000002', 'Electronics', 'Laptop - Silver colored, MacBook Pro 13 with charger cable', 'Downtown Area', 'Coffee shop Lost and Found', 'Silver', 'Apple', NOW() - INTERVAL '1 day', 40.7130, -74.0065),
  ('00000000-0000-0000-0000-000000000002', 'Accessories', 'Sony wireless headphones blue color with carrying case included', 'Campus Building', 'Lost and Found desk', 'Blue', 'Sony', NOW(), 40.8078, -73.9620),
  ('00000000-0000-0000-0000-000000000002', 'Clothing', 'Red Nike backpack with side pockets found in park area', 'Park Vicinity', 'Park administration office', 'Red', 'Nike', NOW() - INTERVAL '2 days', 40.7835, -73.9660);
