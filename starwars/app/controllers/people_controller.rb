class PeopleController < ApplicationController
  before_action :set_person, only: :show  
  def index
    @people = Person.all
  end
  def show
    
  end

  private
    def set_person
      @person = Person.find(params[:id])
    end
end
