module Insurance
  class Company
    attr_accessor :pile_of_cash, :customers

    def initialize
      @customers = []
      @premium_payments = []
      @loans = []
      @penalties = []
    end

    def add_customer(customer)
      customers << Customer.new(customer, self)
    end

    def collect(amount, from)
      @premium_payments << {:amount => amount, :customer => from}
    end

    def pile_of_cash
      @premium_payments.map { |payment| payment[:amount] }
        .inject(:+)
    end

    def penalize(amount, customer)
      @penalties << {:amount => amount, :customer => customer}
    end

    def loan_balance_of(customer)
      loans = @loans
        .select { |loan| loan[:customer] == customer }
        .map { |loan| loan[:amount] }
        .inject(:+) || 0
    end

    def penalties_on(customer)
      penalties = @penalties
        .select { |penalty| penalty[:customer] == customer }
        .map { |penalty| penalty[:amount] }
        .inject(:+) || 0
    end

    def cash_value_of(customer)
      premiums = @premium_payments
        .select { |payment| payment[:customer] == customer }
        .map { |payment| payment[:amount] }
        .inject(:+) || 0

      loans = loan_balance_of(customer)
      penalties = penalties_on(customer)

      premiums - penalties - loans
    end

    def loan(amount, to)
      raise StandardError if amount > cash_value_of(to)
      @loans << {:amount => amount, :customer => to}
    end
  end

  class Customer
    attr_accessor :info, :company

    def initialize(info={:name => 'John Doe'}, company=Company.new)
      @info = info
      @company = company
    end

    def make_payment(amount)
      @company.collect(amount, self)
    end

    def cash_value
      company.cash_value_of(self)
    end

    def withdraw(amount)
      company.loan(amount, self)
    end
  end
end
