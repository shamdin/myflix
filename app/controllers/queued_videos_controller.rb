class QueuedVideosController < ApplicationController
  before_action :require_user
  before_action :set_queue 
  
  def index
  end

  def create
    video = Video.find(params[:video_id])
    in_queue = @queued_videos.where(video_id: video.id)
    position = @queued_videos.count + 1

    QueuedVideo.create(user_id: current_user.id, video_id: video.id, queue_position: position) unless in_queue.any?
    
    respond_to do |format|
      format.js
      format.html { flash[:error] = "That video is already in your queue."
                    redirect_to video_path(video) 
                  }
    end
  end

  def destroy
    queued_video = @queued_videos.find_by(user_id: current_user.id, video_id: params[:id]) 
    queued_video.destroy
    current_user.normalize_queue # method on the user model
    redirect_to my_queue_path
  end

  def update
    begin
      update_queue  
    rescue ActiveRecord::RecordInvalid # if the user enters non integer values for the position we will roll back changes and flash error
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
        update_rating(queued_video, new_queue) if new_queue['rating'] != "" 
      end
    end   
  end

  def update_rating(queued_video, new_queue)
    review = Review.find_by(user_id: current_user.id, video_id: queued_video.video.id)
    if review # exists?
      review.update_attributes!(rating: new_queue['rating'])
    else # create a new review
      Review.create(rating: new_queue['rating'], video_id: queued_video.video.id, 
                    user_id: current_user.id, body: "Hmm, I guess I'll rate this movie!")
    end
  end
end