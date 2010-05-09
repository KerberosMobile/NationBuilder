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
