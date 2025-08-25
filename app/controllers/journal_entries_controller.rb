class JournalEntriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_journal_entry, only: [:show, :edit, :update]

  # List only current user's entries
  def index
    @journal_entries = current_user.journal_entries.order(created_at: :desc)
  end

  # Show only if belongs to user
  def show
  end

  def edit
  end

  def update
    if @journal_entry.update(journal_entry_params)
      redirect_to @journal_entry, notice: 'Journal entry updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def new
    @journal_entry = current_user.journal_entries.build
  end

  def create
    @journal_entry = current_user.journal_entries.build(journal_entry_params)
    if @journal_entry.save
      redirect_to @journal_entry, notice: 'Journal entry created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
    def set_journal_entry
      @journal_entry = current_user.journal_entries.find(params[:id])
    end

    def journal_entry_params
      params.require(:journal_entry).permit(:title, :body)
    end
end

