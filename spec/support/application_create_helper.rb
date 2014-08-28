module ApplicationCreateHelper
  def create_application(options={})
    Facemock::Database::Application.new(options).save!
  end
end
