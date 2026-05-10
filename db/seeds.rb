# Create Admin User
admin = User.find_or_create_by!(email: 'admin@fixguru.com') do |u|
  u.password = 'admin123'
  u.password_confirmation = 'admin123'
  u.role = 'admin'
  u.status = 'active'
end

puts "Created admin user: #{admin.email}"

# Create Categories
categories = [
  { name: 'Plumbing', description: 'Plumbing services including repairs, installations, and maintenance' },
  { name: 'Electrical', description: 'Electrical work including wiring, repairs, and installations' },
  { name: 'Carpentry', description: 'Carpentry services for furniture, doors, and woodwork' },
  { name: 'Painting', description: 'Interior and exterior painting services' },
  { name: 'Cleaning', description: 'House cleaning and maintenance services' },
  { name: 'AC Repair', description: 'Air conditioning installation, repair, and maintenance' },
  { name: 'Appliance Repair', description: 'Home appliance repair and maintenance' },
  { name: 'Roofing', description: 'Roof repair and installation services' }
]

categories.each do |cat_data|
  Category.find_or_create_by!(name: cat_data[:name]) do |category|
    category.description = cat_data[:description]
  end
end

puts "Created #{Category.count} categories"

# Create sample service seeker
seeker = User.find_or_create_by!(email: 'seeker@example.com') do |u|
  u.password = 'password123'
  u.password_confirmation = 'password123'
  u.role = 'service_seeker'
  u.status = 'active'
end
seeker.subscriptions.find_or_create_by!(plan_type: 'free') do |s|
  s.status = 'active'
  s.start_date = Date.current
end

puts "Created sample seeker: #{seeker.email}"

# Create sample service provider
provider = User.find_or_create_by!(email: 'provider@example.com') do |u|
  u.password = 'password123'
  u.password_confirmation = 'password123'
  u.role = 'service_provider'
  u.status = 'active'
end
provider.subscriptions.find_or_create_by!(plan_type: 'standard') do |s|
  s.status = 'active'
  s.start_date = Date.current
  s.end_date = Date.current + 1.month
end

provider_profile = provider.provider_profile || provider.build_provider_profile(
  full_name: 'Ahmed Ali',
  cnic_number: '12345-1234567-1',
  skills: 'Plumbing, Electrical, General Repairs',
  experience: '10 years of experience in home repairs',
  service_areas: 'Karachi, Lahore, Islamabad',
  verification_status: 'approved'
)
provider_profile.save!

puts "Created sample provider: #{provider.email}"

puts "\nSeeds completed successfully!"
puts "Admin: admin@fixguru.com / admin123"
puts "Seeker: seeker@example.com / password123"
puts "Provider: provider@example.com / password123"
