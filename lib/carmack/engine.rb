class Carmack::Engine < Rails::Engine
  engine_name :carmack

  initializer :carmack do |app|
    Carmack::Subscriber.attach_to :carmack
  end
end
