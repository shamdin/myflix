module StripeWrapper # extract Stripe to a wrapper (custom object) so we can access it app wide
	class Charge
	  attr_reader :response, :status # allows us access response and status in our helper methods

    def initialize (response, status)
      @response = response
      @status = status
    end

	  def self.create(options={}) # pass in a hash that Stripe needs to process payments
	  	StripeWrapper.set_api_key
	  	begin
	  	  response = Stripe::Charge.create(amount: options[:amount], currency: "usd", card: options[:card], description: options[:description]) # :card is the stripe token generated by the API
	      Charge.new(response, :success)
	    rescue Stripe::CardError => e
	      Charge.new(e, :error)
	    end
	  end
	  
    def successful? # boolean method that asserts to true if the charge goes through succesfully
      status == :success
    end
    	
    def error_message # helper method that will parse out the error message if the card charge fails
      response.message
    end
	end
  
  class Customer
    attr_reader :response, :status
    
    def initialize(response, status)
      @response = response
      @status = status  
    end

    def self.create(user,token)
      StripeWrapper.set_api_key
      begin
        response = Stripe::Customer.create(plan: "Basic", card: token, email: user.email)
        Customer.new(response, :success)
      rescue Stripe::CardError => e
        Customer.new(e, :error)  
      end
    end
   
    def successful?
      status == :success
    end
    
    def customer_token
      response.id
    end

    def error_message
      response.message
    end
  end

  def self.set_api_key
    Stripe.api_key = ENV["STRIPE_SECRET_KEY"]
  end
end