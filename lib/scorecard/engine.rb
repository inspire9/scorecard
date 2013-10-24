class Scorecard::Engine < Rails::Engine
  engine_name :scorecard

  initializer :scorecard do |app|
    Scorecard::Subscriber.attach_to :scorecard
  end
end
