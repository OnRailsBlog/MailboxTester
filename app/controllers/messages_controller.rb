class MessagesController < ApplicationController

  def index
	@page = params[:page] ? params[:page].to_i : FIRST_PAGE
	@messages = ActionMailbox::InboundEmail.order(created_at: :desc).limit(ITEMS_PER_PAGE).offset(@page * ITEMS_PER_PAGE)
	@total_pages = ActionMailbox::InboundEmail.count / ITEMS_PER_PAGE
  end
end
