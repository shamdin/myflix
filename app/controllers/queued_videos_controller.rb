class QueuedVideosController < ApplicationController
  before_action :require_user
  before_action :set_queue#, only: [:index, :create, :destroy, :update]
  
  def index
  end

  def create
    video = Video.find(params[:video_id])
    in_queue = @queued_videos.where(video_id: video.id)
    position = @queued_videos.count + 1
      
    if in_queue.any? # this code might be redundant, since in the view the button changes if the video is in the queue
      flash[:error] = "That video is already in your queue."
      redirect_to :back
    else
      QueuedVideo.create(user_id: current_user.id, video_id: video.id, queue_position: position)
      redirect_to :back # re-direct back to video page, not the queue page
    end
  end

  def destroy
    queued_video = @queued_videos.find_by(user_id: current_user.id, video_id: params[:id]) 
    queued_video.destroy
    current_user.normalize_queue
    redirect_to my_queue_path
  end

  def update
    begin
      update_queue  
    rescue ActiveRecord::RecordInvalid
       flash[:error] = "Invalid position numbers."
       redirect_to my_queue_path
       return
    end
    
    current_user.normalize_queue
    redirect_to my_queue_path
  end

  private
  def set_queue # this will set the queue to the current users' queue
    @queued_videos = current_user.queued_videos
  end
  
  def update_queue
    ActiveRecord::Base.transaction do
      params[:queued_videos].each do |new_queue|
        queued_video = @queued_videos.find(new_queue["id"])  
        queued_video.update_attributes!(queue_position: new_queue["position"])
      end
    end   
  end
end