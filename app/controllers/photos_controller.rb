class PhotosController < ApplicationController
  def create
    photo = Photo.new(:user_id => current_user.id, image: params[:Filedata])
    if photo.save
      current_user.update_attribute(:avatar, photo.image.url)
      render :json => { :id => photo.id, :url => photo.image.url }
    end
  end
end
