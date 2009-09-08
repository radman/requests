class Request < ActiveRecord::Base
  validates_presence_of :recipient_email

  def accept!
    self.response = :accept
    self.save!
  end

end