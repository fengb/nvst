RailsAdmin.config do |config|
  config.main_app_name = ['NVST', 'Admin']
  # config.main_app_name = ->(controller) { [Rails.application.engine_name.titleize, controller.params['action'].titleize] }

  # RailsAdmin may need a way to know who the current user is]
  config.current_user_method { current_admin }
  config.authenticate_with   { authenticate_admin! }

  config.audit_with :history, 'Admin'
  # config.audit_with :paper_trail, 'User'

  # Display empty fields in show views:
  # config.compact_show_view = false

  # Number of default rows per-page:
  # config.default_items_per_page = 20

  config.included_models = %w[Admin User Investment Contribution Transfer Trade Event Expense]

  # Label methods for model instances:
  config.label_methods = [:title, :name]

  config.navigation_static_links = {
    'Portfolio'       => '/admin/portfolio',
    'Tax Docs'        => '/admin/tax_docs',
    'User Summaries'  => '/admin/user_summaries',
  }
end
