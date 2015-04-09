# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/MethodLength
# rubocop:disable Metrics/AbcSize
class DemoCreator
  attr_reader :kickoff

  def initialize(bakery)
    @bakery = bakery
    @kickoff = @bakery.kickoff_time + 1.hour
  end

  def run
    default_route
    multi_grain_loaf
    nicoise_baguette
    chive_pain_au_lait
    client
    order
    run_one_week_shipments
  end

  def run_one_week_shipments
    (0..7).to_a.reverse_each do |days|
      date = Date.today - days.days
      process_time = Time.new(date.year, date.month, date.day, kickoff.hour, kickoff.min, kickoff.sec)
      KickoffService.new(@bakery, process_time).run
    end
  end

  def dark_rye_flour
    @_dark_rye_flour ||= Ingredient.create!(
      bakery: @bakery,
      name: 'Dark Rye Flour',
      price: 22.00,
      measure: 40,
      unit: :lb,
      ingredient_type: :flour
    )
  end

  def white_flour
    @_white_flour ||= Ingredient.create!(
      bakery: @bakery,
      name: 'White Flour',
      price: 1.10,
      measure: 1,
      unit: :kg,
      ingredient_type: :flour
    )
  end

  def whole_wheat_flour
    @_whole_wheat_flour ||= Ingredient.create!(
      bakery: @bakery,
      name: 'Whole Wheat Flour',
      price: 1.30,
      measure: 1,
      unit: :kg,
      ingredient_type: :flour
    )
  end

  def yeast
    @_yeast ||= Ingredient.create!(
      bakery: @bakery,
      name: 'Yeast',
      price: 75.00,
      measure: 20,
      unit: :lb,
      ingredient_type: :ingredient
    )
  end

  def water
    @_water ||= Ingredient.create!(
      bakery: @bakery,
      name: 'Water',
      price: 0.00,
      measure: 0,
      unit: :g,
      ingredient_type: :ingredient
    )
  end

  def nicoise_olives
    @_nicoise_olives ||= Ingredient.create!(
      bakery: @bakery,
      name: 'Nicoise Olives',
      price: 40.00,
      measure: 1,
      unit: :lb,
      ingredient_type: :ingredient
    )
  end

  def chives
    @_chives ||= Ingredient.create!(
      bakery: @bakery,
      name: 'Chives',
      price: 15.00,
      measure: 1,
      unit: :lb,
      ingredient_type: :ingredient
    )
  end

  def nicoise_olive_inclusion
    @_nicoise_olive_inclusion ||= Recipe.create!(
      bakery: @bakery,
      recipe_type: :inclusion,
      name: 'Nicoise Olives',
      lead_days: 1,
      recipe_items: [RecipeItem.create!(
        bakers_percentage: 15,
        inclusionable: nicoise_olives
      )]
    )
  end

  def dark_rye
    @_dark_rype ||= Recipe.create!(
      bakery: @bakery,
      recipe_type: :inclusion,
      name: 'Dark Rye',
      lead_days: 2,
      recipe_items: [RecipeItem.create!(
        bakers_percentage: 1,
        inclusionable: dark_rye_flour
      )]
    )
  end

  def chive_pain_au_lait_inclusion
    Recipe.create!(
      bakery: @bakery,
      recipe_type: :inclusion,
      name: 'Chive Pain au Lait',
      lead_days: 1,
      recipe_items: [RecipeItem.create!(
        bakers_percentage: 2,
        inclusionable: chives
      )]
    )
  end

  def multi_grain_dough
    Recipe.create!(
      bakery: @bakery,
      recipe_type: :dough,
      name: 'Multi-Grain',
      mix_size: 12,
      mix_size_unit: :kg,
      lead_days: 2,
      recipe_items: [
        RecipeItem.create!(bakers_percentage: 80, inclusionable: white_flour),
        RecipeItem.create!(bakers_percentage: 20, inclusionable: whole_wheat_flour),
        RecipeItem.create!(bakers_percentage: 0.4, inclusionable: yeast),
        RecipeItem.create!(bakers_percentage: 85, inclusionable: water)
      ]
    )
  end

  def baguette_dough
    Recipe.create!(
      bakery: @bakery,
      recipe_type: :dough,
      name: 'Baguette',
      mix_size: 50,
      mix_size_unit: :kg,
      lead_days: 2,
      recipe_items: [
        RecipeItem.create!(bakers_percentage: 100, inclusionable: white_flour),
        RecipeItem.create!(bakers_percentage: 0.4, inclusionable: yeast),
        RecipeItem.create!(bakers_percentage: 40, inclusionable: water)
      ]
    )
  end

  def pain_au_lait_dough
    Recipe.create!(
      bakery: @bakery,
      recipe_type: :dough,
      name: 'Pain au Lait',
      mix_size: 70,
      mix_size_unit: :kg,
      lead_days: 3,
      recipe_items: [
        RecipeItem.create!(bakers_percentage: 100, inclusionable: white_flour),
        RecipeItem.create!(bakers_percentage: 2.2, inclusionable: yeast),
        RecipeItem.create!(bakers_percentage: 30, inclusionable: water)
      ]
    )
  end

  def multi_grain_loaf
    return @_multi_grain_loaf if @_multi_grain_loaf
    @_multi_grain_loaf = Product.create!(
      bakery: @bakery,
      name: 'Multi-Grain Loaf',
      product_type: :bread,
      description: 'A delicious loaf',
      weight: 1200,
      unit: :g,
      over_bake: 0,
      base_price: 5.80,
      motherdough: multi_grain_dough,
      inclusion: dark_rye
    )
    PriceVarient.create!(product: @_multi_grain_loaf, price: 5.50, quantity: 10)
  end

  def nicoise_baguette
    @_nicoise_baguette ||= Product.create!(
      bakery: @bakery,
      name: 'Nicoise Baguette',
      product_type: :bread,
      description: 'The finest baguette',
      weight: 50,
      unit: :g,
      over_bake: 0,
      base_price: 1.50,
      motherdough: baguette_dough,
      inclusion: nicoise_olive_inclusion
    )
  end

  def chive_pain_au_lait
    @_chive_pain_au_lait ||= Product.create!(
      bakery: @bakery,
      name: 'Chive Pain Au Lait',
      product_type: :bread,
      weight: 40,
      unit: :g,
      over_bake: 2,
      base_price: 0.75,
      motherdough: pain_au_lait_dough,
      inclusion: chive_pain_au_lait_inclusion
    )
  end

  def default_route
    @_defaut_route ||= Route.create!(
      bakery: @bakery,
      name: 'Default Route',
      active: true,
      departure_time: Chronic.parse('6 am')
    )
  end

  def client
    @_client ||= Client.create!(
      bakery: @bakery,
      name: "Wizard's Coffee",
      business_phone: '917-805-3079',
      active: true,
      delivery_address_street_1: '64 Allen St',
      delivery_address_city: 'New York',
      delivery_address_state: 'NY',
      delivery_address_zipcode: '10002',

      billing_address_street_1: '64 Allen St',
      billing_address_city: 'New York',
      billing_address_state: 'NY',
      billing_address_zipcode: '10002',

      accounts_payable_contact_name: 'Francis Gulotta',
      accounts_payable_contact_phone: '917-805-3079',
      accounts_payable_contact_email: 'francis@wizarddevelopment.com',

      primary_contact_name: 'Francis Gulotta',
      primary_contact_phone: '917-805-3079',
      primary_contact_email: 'francis@wizarddevelopment.com',

      billing_term: :net_30,
      delivery_fee_option: :no_delivery_fee
    )
  end

  def order
    Order.create!(
      bakery: @bakery,
      order_type: 'standing',
      start_date: Date.today - 1.week,
      end_date: nil,
      client: client,
      route: default_route,
      order_items: [OrderItem.new(
        product: nicoise_baguette,
        monday: 5,
        tuesday: 5,
        wednesday: 4,
        thursday: 5,
        friday: 5,
        saturday: 10,
        sunday: 0
      )]
    )
  end
end
# rubocop:enable Metrics/ClassLength
# rubocop:enable Metrics/MethodLength
# rubocop:enable Metrics/AbcSize
