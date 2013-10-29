class Scorecard::ClearWorker
  include Sidekiq::Worker

  def perform(class_name, id)
    Scorecard::Cleaner.points class_name.constantize.find(id)
  end
end
