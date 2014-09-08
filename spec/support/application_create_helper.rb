module ApplicationCreateHelper
  def create_application(options={})
    Facemock::Application.create!(options)
  end
end
