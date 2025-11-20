# Create Admin User
admin = User.create!(
  email: 'admin@fixguru.com',
  password: 'admin123',
  password_confirmation: 'admin123',
  role: 'admin',
  status: 'active'
)

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
seeker = User.create!(
  email: 'seeker@example.com',
  password: 'password123',
  password_confirmation: 'password123',
  role: 'service_seeker',
  status: 'active'
)
seeker.subscriptions.create!(plan_type: 'free', status: 'active', start_date: Date.current)

puts "Created sample seeker: #{seeker.email}"

# Create sample service provider
provider = User.create!(
  email: 'provider@example.com',
  password: 'password123',
  password_confirmation: 'password123',
  role: 'service_provider',
  status: 'active'
)
provider.subscriptions.create!(plan_type: 'standard', status: 'active', start_date: Date.current, end_date: Date.current + 1.month)

provider_profile = provider.build_provider_profile(
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
