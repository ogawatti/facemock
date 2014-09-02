module ApplicationCreateHelper
  def create_application(options={})
    Facemock::Database::Application.create!(options)
  end
end
