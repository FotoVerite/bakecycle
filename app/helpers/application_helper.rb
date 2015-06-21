module ApplicationHelper
  def render_side_nav?
    @_render_side_nav
  end

  def class_for_main_content
    return 'large-10 medium-12 small-12 columns light-grey-bg-pattern' if render_side_nav?
    'medium-6 medium-offset-3 small-10 small-offset-1 columns light-grey-bg-pattern'
  end

  def active_nav?(*sections)
    'active show-nav' if sections.include? @_active_nav
  end

  def full_title(page_title = nil)
    base_title = 'Bakecycle'
    return base_title if page_title.empty?
    "#{page_title} - #{base_title}".html_safe
  end

  def resque_info_table
    render partial: 'resque_info_table', locals: { info: Resque.info }
  end

  # rubocop:disable Metrics/MethodLength
  def funny_loading_message
    [
      'Borrowing some flour',
      'Waiting for the report to rise',
      'Double checking the weights',
      'Proofing the report',
      'Was that one egg or two?',
      'Toasting the oats',
      'Loading the kneaded info',
      'Reticulating splines',
      'Mixing the customers and orders',
      'Measuring twice and mixing once',
      'Two parts database and one part you',
      'Tasking a worker processes to generate your report, store it in our storage system and deliver it to you',
      'Generating pie charts',
      'Get ready to roll',
      'Let them heat cake',
      'This should pan out nicely',
      'I can\'t believe it\'s not batter',
      'Generating reports, honest! We\'re not loafing around',
      'Hope you\'re having a challah good day!',
      'I hate to brioche the subject but this report is pretty big!',
      'Your report is almost ready to dough!'
    ].sample
  end
  # rubocop:enable Metrics/MethodLength

  def loading_indicator
    render 'loading_indicator'
  end
end
