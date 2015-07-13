class Registration
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :first_name, :last_name, :bakery_name, :email, :password, :bakery, :user,
                :plan, :id, :card_number, :stripe_token
  attr_reader :card_zipcode, :card_code, :card_month, :card_year, :card_token

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :bakery_name, presence: true
  validates :email, presence: true, format: { with: Devise.email_regexp }
  validates :password, presence: true
  validates :plan, presence: true
  validate :bakery_valid?
  validate :user_valid?

  def self.build(*args)
    new(*args)
  end

  def save
    save!
  rescue ActiveRecord::RecordInvalid
    false
  end

  def save!
    raise ActiveRecord::RecordInvalid, self unless valid?
    ActiveRecord::Base.transaction do
      bakery.save! && user.save!
    end
    true
  end

  def save_and_setup
    save && create_demo # && create_stripe_customer
  end

  def month
    1..12
  end

  def year
    start_date = Time.zone.now.year
    end_date = Time.zone.now.year + 15
    start_date..end_date
  end

  def bakery
    @bakery ||= Bakery.new(
      name: bakery_name,
      plan: plan,
      kickoff_time: Chronic.parse('4 pm'),
      quickbooks_account: 'Sales:Sales - Wholesale'
    )
  end

  def user
    @user ||= User.new(
      name: "#{first_name} #{last_name}",
      password: password,
      email: email,
      bakery: bakery,
      user_permission: 'manage',
      bakery_permission: 'manage',
      product_permission: 'manage',
      client_permission: 'manage',
      shipping_permission: 'manage',
      production_permission: 'manage'
    )
  end

  def plan_id=(plan_id)
    self.plan = Plan.find_by(id: plan_id)
  end

  def plan_id
    plan.id if plan
  end

  private

  def create_stripe_customer
    StripeUserCreateJob.perform_later(user, stripe_token)
    true
  end

  def create_demo
    DemoCreatorJob.perform_later(bakery)
    true
  end

  def bakery_valid?
    return if bakery.valid?
    if bakery.errors[:name].any?
      errors.add(:bakery_name, bakery.errors[:name].first)
    else
      errors.add(:base, 'We had a problem creating your bakery')
    end
  end

  def user_valid?
    return if user.valid?
    if user.errors[:email].any?
      errors.add(:email, user.errors[:email].first)
    else
      errors.add(:base, 'We had a problem creating your user')
    end
  end
end
