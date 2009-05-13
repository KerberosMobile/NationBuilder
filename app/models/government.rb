class Government < ActiveRecord::Base

  extend ActiveSupport::Memoizable

  named_scope :active, :conditions => "status = 'active'"
  
  belongs_to :official_user, :class_name => "User"
  belongs_to :color_scheme
  belongs_to :picture
  
  validates_presence_of     :name
  validates_length_of       :name, :within => 3..60

  validates_presence_of     :short_name
  validates_uniqueness_of   :short_name, :case_sensitive => false
  ReservedShortnames = %w[admin blog dev ftp mail pop pop3 imap smtp stage stats status www jim jgilliam gilliam feedback facebook builder nationbuilder]
  validates_exclusion_of    :short_name, :in => ReservedShortnames, :message => 'is already taken'  

  validates_presence_of     :admin_name
  validates_length_of       :admin_name, :within => 3..60

  validates_presence_of     :admin_email
  validates_length_of       :admin_email, :within => 3..100, :allow_nil => true, :allow_blank => true
  validates_format_of       :admin_email, :with => /^[-^!$#%&'*+\/=3D?`{|}~.\w]+@[a-zA-Z0-9]([-a-zA-Z0-9]*[a-zA-Z0-9])*(\.[a-zA-Z0-9]([-a-zA-Z0-9]*[a-zA-Z0-9])*)+$/x

  validates_presence_of     :email
  validates_length_of       :email, :within => 3..100, :allow_nil => true, :allow_blank => true
  validates_format_of       :email, :with => /^[-^!$#%&'*+\/=3D?`{|}~.\w]+@[a-zA-Z0-9]([-a-zA-Z0-9]*[a-zA-Z0-9])*(\.[a-zA-Z0-9]([-a-zA-Z0-9]*[a-zA-Z0-9])*)+$/x

  validates_presence_of     :tags_name
  validates_length_of       :tags_name, :maximum => 20
  validates_presence_of     :briefing_name
  validates_length_of       :briefing_name, :maximum => 20
  validates_presence_of     :currency_name
  validates_length_of       :currency_name, :maximum => 30
  validates_presence_of     :currency_short_name
  validates_length_of       :currency_short_name, :maximum => 3
  
  validates_inclusion_of    :homepage, :in => Homepage::NAMES.collect{|n|n[0]}

  liquid_methods :short_name, :domain_name, :name, :tagline, :name_with_tagline, :email, :official_user_id, :official_user_short_name,:official_user_priorities_count, :has_official?, :official_user_name, :target, :is_tags, :is_facebook?, :is_legislators?, :admin_name, :admin_email, :tags_name, :briefing_name, :currency_name, :currency_short_name, :priorities_count, :points_count, :documents_count, :users_count, :contributors_count, :partners_count, :endorsements_count, :logo, :logo_small, :logo_tiny, :logo_large, :logo_dimensions, :picture_id, :base_url, :mission, :tags_name_plural

  after_save :clear_cache
  before_save :last_minute_checks
  
  def last_minute_checks
    self.homepage = 'top' if not self.is_tags? and self.homepage == 'index'
  end
  
  def clear_cache
    if WH2_CONFIG["multiple_government_mode"]
      Rails.cache.delete('government-'+domain_name)
    else
      Rails.cache.delete('government')
    end
    return true
  end
  
  def switch_db
    config = Rails::Configuration.new
    new_spec = config.database_configuration[RAILS_ENV].clone
    new_spec["database"] =  db_name
    ActiveRecord::Base.establish_connection(new_spec)    
    Government.current = self   
  end
  
  def switch_db_back
    config = Rails::Configuration.new
    ActiveRecord::Base.establish_connection(config.database_configuration[RAILS_ENV])    
  end

  def self.current  
    Thread.current[:government]  
  end  
  
  def self.current=(government)  
    raise(ArgumentError,"Invalid government. Expected an object of class 'Government', got #{government.inspect}") unless government.is_a?(Government)
    Thread.current[:government] = government
  end

  def cache
    ActiveSupport::Cache.lookup_store(:mem_cache_store, :namespace => db_name)
  end
  memoize :cache
  
  def base_url
    return domain_name if attribute_present?("domain_name")
    return short_name + '.nationbuilder.com'
  end

  def name_with_tagline
    return name unless attribute_present?("tagline")
    name + ": " + tagline
  end
  
  def update_counts
    switch_db if WH2_CONFIG["multiple_government_mode"]
    self.users_count = User.active.count
    self.priorities_count = Priority.published.count
    self.endorsements_count = Endorsement.active_and_inactive.count
    self.partners_count = Partner.active.count
    self.points_count = Point.published.count
    self.documents_count = Document.published.count
    self.contributors_count = User.active.at_least_one_endorsement.contributed.count
    self.official_user_priorities_count = official_user.endorsements_count if has_official?
    switch_db_back if WH2_CONFIG["multiple_government_mode"]
    save_with_validation(false)
  end  
  
  def has_official?
    attribute_present?("official_user_id")
  end
  
  def official_user_name
    official_user.name if official_user
  end
  
  def official_user_name=(n)
    self.official_user = User.find_by_login(n) unless n.blank?
  end  
  
  def has_google_analytics?
    attribute_present?("google_analytics_code")
  end
  
  def logo
    return nil unless has_picture?
    '<div class="logo"><a href="/"><img src="/pictures/get/' + picture_id.to_s + '" border="0"></a></div>'
  end
  
  def logo_url
    "/pictures/get/" + picture_id.to_s
  end
  
  def logo_dimensions
    return nil unless picture
    picture.width.to_s + 'x' + picture.height.to_s
  end
  
  def logo_large
    return nil unless has_picture?
    '<div class="logo_small"><a href="/"><img src="/pictures/get_450/' + picture_id.to_s + '" border="0"></a></div>'
  end  
  
  def logo_small
    return nil unless has_picture?
    '<div class="logo_small"><a href="/"><img src="/pictures/logo/' + picture_id.to_s + '" border="0"></a></div>'
  end
  
  def logo_tiny
    return nil unless has_picture?
    '<div class="logo_tiny"><a href="/"><img src="/pictures/get_18_high/' + picture_id.to_s + '" border="0"></a></div>'
  end

  def has_picture?
    attribute_present?("picture_id")
  end
  
  def tags_name_plural
    tags_name.pluralize
  end

end
