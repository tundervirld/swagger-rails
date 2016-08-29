# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
if User.count == 0
	User.create(:name => "a", :email => "a@a.com")
	User.create(:name => "b", :email => "b@b.com", :state => false)
	User.create(:name => "c", :email => "c@c.com", :state => nil)
	User.create(:name => "d", :email => "d@d.com", :state => true)
	User.create(:name => "e", :email => "e@e.com", :state => true)
end