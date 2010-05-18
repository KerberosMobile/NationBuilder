# users

Factory.sequence :login do |n|
  "teletubby#{n}"
end

Factory.sequence :email do |n|
  "teletubby#{n}@example.com"
end

Factory.define :user do |u|
  u.login { Factory.next(:login) }
  u.email { Factory.next(:email) }
  u.password 'toodeloo'
  u.password_confirmation 'toodeloo'
  u.capitals_count 9999999
  u.locale 'en'
end

Factory.define :government do |g|
  g.name 'home sweet home'
  g.short_name 'single'
  g.admin_name 'casasucasa'
  g.admin_email { Factory.next(:email) }
  g.email { Factory.next(:email) }
  g.tags_name 'belga'
  g.briefing_name 'euhm'
  g.currency_name 'linden dollars'
  g.currency_short_name 'ldd' 
end

Factory.sequence :priority_name do |n|
  "Change the world #{n}"
end

Factory.define :priority do |p|
  p.name { Factory.next(:priority_name) }
end

Factory.define :change do |c|
  c.association :priority
  c.new_priority { Factory(:priority) }
  c.association :user
end

Factory.define :vote do |v|
  v.association :change
  v.association :user
end
