class Shredder < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :area_id, :inches, :mobile, :confirmed, :active
  validates_presence_of :mobile, :area_id, :inches
  validates_length_of :mobile, :is => 10
  validates_numericality_of :inches
  belongs_to :area
  has_many :alerts
  has_many :subscriptions
  has_many :text_subscriptions
  has_many :voice_subscriptions
  before_create :create_confirmation_code
  validates_uniqueness_of :mobile, :scope => :area_id
  scope :notices_for, lambda{|inches,area_id| where("area_id = ? and inches <= ?",area_id,inches)}
  GREETS = ['SICKBURD','Gaper','Powderpuff','Powstar','Child of Ullr','Brah','Bro','Gnarsef','Brosef','Sickter','Shredder','Gaper Gapper','Shredhead','Freshie Fiend','Snow Bunny','Snow Angel','Conehead']
  DEFAULT_MESSAGE = 'FRESHIEZ! {{area}} is reporting {{new_snow}}" of new snow. Base Temp: {{base_temp}}. Reported At: {{report_time}}'

  def send_confirmation
    Twilio.connect(Cone::Application.config.twilio_sid, Cone::Application.config.twilio_auth)
    Twilio::Sms.message(Cone::Application.config.twilio_number, self.mobile, "conepatrol.com/confirm confirmation code: #{self.confirmation_code}")
  end

  def mobile_confirm
    return true if self.confirmed
    self.update_attributes(:active => true, :confirmed => true)
    self.text_subscriptions.create(:inches => self.inches, :area_id => self.area_id, :active => true, :message => DEFAULT_MESSAGE)
  end

  def random_name
    GREETS[rand(GREETS.size)]
  end

  def active_subscriptions
    self.subscriptions.find(:all, :conditions => {:active => true})
  end
  
  private

  def create_confirmation_code
    charset = %w{ 2 3 4 6 7 9 A C D E F G H J K M N P Q R T V W X Y Z}
    self.confirmation_code = (0...4).map{ charset.to_a[rand(charset.size)] }.join
    send_confirmation
  end
end
