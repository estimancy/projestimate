class CurrenciesController < ApplicationController
  # GET /currencies
  # GET /currencies.json
  def index
    authorize! :manage_currency, Currency
    @currencies = Currency.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @currencies }
    end
  end

  # GET /currencies/1
  # GET /currencies/1.json
  def show
    authorize! :manage_currency, Currency
    @currency = Currency.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @currency }
    end
  end

  # GET /currencies/new
  # GET /currencies/new.json
  def new
    authorize! :manage_currency, Currency
    @currency = Currency.new

    respond_to do |format|
      format.html # _new.html.erb
      format.json { render json: @currency }
    end
  end

  # GET /currencies/1/edit
  def edit
    authorize! :manage_currency, Currency
    @currency = Currency.find(params[:id])
  end

  # POST /currencies
  # POST /currencies.json
  def create
    authorize! :manage_currency, Currency
    @currency = Currency.new(params[:currency])

    respond_to do |format|
      if @currency.save
        format.html { redirect_to @currency, notice: 'Currency was successfully created.' }
        format.json { render json: @currency, status: :created, location: @currency }
      else
        format.html { render action: "new" }
        format.json { render json: @currency.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /currencies/1
  # PUT /currencies/1.json
  def update
    authorize! :manage_currency, Currency
    @currency = Currency.find(params[:id])

    respond_to do |format|
      if @currency.update_attributes(params[:currency])
        format.html { redirect_to @currency, notice: 'Currency was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @currency.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /currencies/1
  # DELETE /currencies/1.json
  def destroy
    authorize! :manage_currency, Currency
    @currency = Currency.find(params[:id])
    @currency.destroy

    respond_to do |format|
      format.html { redirect_to currencies_url }
      format.json { head :ok }
    end
  end
end
