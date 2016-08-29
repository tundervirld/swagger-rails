class UserSerializer < ActiveModel::Serializer
	attributes :id, :name, :email, :state, :is_active
  
	def is_active 
		_state = object.state
		(_state.nil? or _state == false ) ? false : true 
	end 

end
