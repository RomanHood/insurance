require 'spec_helper'
require 'insurance'
RSpec::Expectations.configuration.on_potential_false_positives = :nothing
RSpec.describe Insurance do
  describe Insurance::Company do
    it 'has many customers' do
      expect(subject.customers).to be_an Array
      subject.add_customer({})
      expect(subject.customers.length).to eq(1)
      expect(subject.customers).to all(be_a Insurance::Customer)
    end

    describe '#collect' do
      it 'collects premiums from customers' do
        subject.collect(100, Insurance::Customer.new)
        subject.collect(200, Insurance::Customer.new)
        expect(subject.pile_of_cash).to eq(300)
      end
    end

    describe '#cash_value_of' do
      it 'retrieves the total amount of premiums paid by a customer' do
        customer = Insurance::Customer.new({:name => 'John Doe'}, subject)
        subject.add_customer(customer)
        customer.make_payment(100)
        customer.make_payment(100)
        customer.make_payment(100)

        expect(subject.cash_value_of(customer)).to eq(300)
      end

      context 'if a loan has been taken from the cash value' do
        it 'returns the net amount' do
          customer = Insurance::Customer.new({:name => 'John Doe'}, subject)
          subject.add_customer(customer)
          customer.make_payment(100)
          customer.make_payment(100)
          customer.make_payment(100)
          subject.loan(100, customer)

          expect(subject.cash_value_of(customer)).to eq(200)
        end
      end
    end

    describe '#loan' do
      it 'reduces the cash value balance for the customer' do
        customer = Insurance::Customer.new({:name => 'John Doe'}, subject)
        customer.make_payment(1000)
        subject.loan(500, customer)
        expect(subject.cash_value_of(customer)).to eq(500)
      end

      it 'keeps a record of the loan' do
        customer = Insurance::Customer.new({:name => 'John Doe'}, subject)
        customer.make_payment(1000)
        subject.loan(500, customer)
        expect(subject.loan_balance_of(customer)).to eq(500)
      end

      context 'if loan amount exceeds available cash value for customer' do
        it 'errors' do
          customer = Insurance::Customer.new({:name => 'John Doe'}, subject)
          subject.add_customer(customer)
          customer.make_payment(100)
          expect{subject.loan(200, customer)}.to raise_error
        end
      end
    end

    describe '#penalize' do
      it 'subtracts from the cash value balance of a customer' do
        customer = Insurance::Customer.new({:name => 'John Doe'}, subject)
        subject.add_customer(customer)
        customer.make_payment(1000)
        subject.penalize(200, customer)
        expect(subject.cash_value_of(customer)).to eq(800)
      end

      it 'keeps a record of the penalty' do
        customer = Insurance::Customer.new({:name => 'John Doe'}, subject)
        customer.make_payment(1000)
        subject.loan(500, customer)
        expect(subject.loan_balance_of(customer)).to eq(500)
      end
    end
  end

  describe Insurance::Customer do
    describe '#make_payment' do
      it 'pays premiums to company' do
        subject.make_payment(100)
        expect(subject.company.pile_of_cash).to eq(100)
      end
    end

    describe '#cash_value' do
      it 'retrieves the total amount of premiums paid by a customer' do
        subject.make_payment(100)
        subject.make_payment(100)
        subject.make_payment(100)
        expect(subject.cash_value).to eq(300)
      end
    end

    describe '#withdraw' do
      it 'reduces the cash value balance' do
        subject.make_payment(1000)
        subject.withdraw(500)
        expect(subject.cash_value).to eq(500)
      end
    end
  end
end
