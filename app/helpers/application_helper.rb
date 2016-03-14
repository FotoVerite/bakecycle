module ApplicationHelper
  def render_nav?
    @_render_nav
  end

  def class_for_main_content
    return "large-10 medium-12 small-12 columns light-grey-bg-pattern" if render_nav?
    "medium-6 medium-offset-3 small-10 small-offset-1 columns light-grey-bg-pattern"
  end

  def active_nav?(*sections)
    "active show-nav" if sections.include? @_active_nav
  end

  def full_title(page_title = nil)
    base_title = "Bakecycle"
    return base_title if page_title.empty?
    "#{page_title} - #{base_title}".html_safe
  end

  def resque_info_table
    render partial: "resque_info_table", locals: { info: Resque.info }
  end

  def funny_loading_message
    LoadingMessages.sample
  end

  def loading_indicator
    render "loading_indicator"
  end

  # rubocop:disable Metrics/MethodLength
  def react_component(name, props)
    html = <<-eos
    <script>
    (function(){
      var name = #{name.to_json};
      var props = #{props.to_json};
      var node = document.createElement('div');
      node.setAttribute('data-reactComponent', name);

      var scripts = document.getElementsByTagName('script');
      var scriptTag = scripts[scripts.length-1];
      scriptTag.parentNode.insertBefore(node, scriptTag);

      window.reactComponents = window.reactComponents || [];
      window.reactComponents.push([name, props, node]);
    })();
    </script>
    eos
    html.html_safe
  end
  # rubocop:enable Metrics/MethodLength
end
