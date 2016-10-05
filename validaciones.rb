class User < ActiveRecord::Base
# Implementa los métodos y validaciones de tu modelo aquí. 
validates :email, :format => { :with => /\A[^@]+@([^@\.]+\.)+[^@\.]{2,}\z/,:message => "Email forma" }
validates :email, :uniqueness => true
validates :phone, :format => { :with => /\A.*([0-9]+.*){10,}\z/,:message => "Email forma" }
validate :OlderThan



  def name
   self.first_name + " " + self.last_name
  end

  def age
    now = Date.today
    age = now.year - self.birthday.year - ((now.month > self.birthday.month || (now.month == self.birthday.month && now.day >= self.birthday.day)) ? 0 : 1)
  end

  def OlderThan
    now = Date.today
    age = now.year - self.birthday.year - ((now.month > self.birthday.month || (now.month == self.birthday.month && now.day >= self.birthday.day)) ? 0 : 1)
    if age >= 18 then true else false end
  end

  def OlderThan
    errors.add(:birthday, "need 18") if
      !birthday.blank? and birthday.year > 1998
  end

end
  
