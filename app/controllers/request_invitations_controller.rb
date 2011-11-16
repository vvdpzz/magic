class RequestInvitationsController < ApplicationController
  # GET /request_invitations
  # GET /request_invitations.json
  def index
    @request_invitations = RequestInvitation.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @request_invitations }
    end
  end

  # GET /request_invitations/1
  # GET /request_invitations/1.json
  def show
    @request_invitation = RequestInvitation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @request_invitation }
    end
  end

  # GET /request_invitations/new
  # GET /request_invitations/new.json
  def new
    @request_invitation = RequestInvitation.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @request_invitation }
    end
  end

  # GET /request_invitations/1/edit
  def edit
    @request_invitation = RequestInvitation.find(params[:id])
  end

  # POST /request_invitations
  # POST /request_invitations.json
  def create
    @request_invitation = RequestInvitation.new(params[:request_invitation])

    respond_to do |format|
      if @request_invitation.save
        format.html { redirect_to @request_invitation, notice: 'Request invitation was successfully created.' }
        format.json { render json: @request_invitation, status: :created, location: @request_invitation }
      else
        format.html { render action: "new" }
        format.json { render json: @request_invitation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /request_invitations/1
  # PUT /request_invitations/1.json
  def update
    @request_invitation = RequestInvitation.find(params[:id])

    respond_to do |format|
      if @request_invitation.update_attributes(params[:request_invitation])
        format.html { redirect_to @request_invitation, notice: 'Request invitation was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @request_invitation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /request_invitations/1
  # DELETE /request_invitations/1.json
  def destroy
    @request_invitation = RequestInvitation.find(params[:id])
    @request_invitation.destroy

    respond_to do |format|
      format.html { redirect_to request_invitations_url }
      format.json { head :ok }
    end
  end
end
