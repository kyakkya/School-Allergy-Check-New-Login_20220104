class ClassroomsController < ApplicationController
  include SchoolsHelper

  before_action :signed_in_teacher
  before_action :system_admin_inaccessible
  before_action :set_school
  before_action :authenticate_teacher!
  before_action :admin_teacher, only: [:index, :edit_using_class, :update_using_class]

  def index
    @active = params[:active].present? ? params[:active] : 1
    classrooms = @school.classrooms.where(using_class: true)
    # 現状seed込みのidの為、アプリ渡す際下記id番号変更必要！
    @first_grade = @school.classrooms.where(class_grade: 1, using_class: true).order(:id)
    @second_grade = @school.classrooms.where(class_grade: 2, using_class: true).order(:id)
    @third_grade = @school.classrooms.where(class_grade: 3, using_class: true).order(:id)
    @fourth_grade = @school.classrooms.where(class_grade: 4, using_class: true).order(:id)
    @fifth_grade = @school.classrooms.where(class_grade: 5, using_class: true).order(:id)
    @sixth_grade = @school.classrooms.where(class_grade: 6, using_class: true).order(:id)
    @other_grade = @school.classrooms.where(class_grade: 7, using_class: true).order(:id)
    @other = @school.teachers.where(classroom_id: nil)
  end

  def edit_using_class
    @classrooms = @school.classrooms.all.order(:id)
  end

  def update_using_class
    @classrooms = @school.classrooms.all.order(:id)
    ActiveRecord::Base.transaction do
      using_class_params.each do |id, item|
        classroom = Classroom.find(id)
        if !classroom.update_attributes(item)
          flash[:danger] = "更新に失敗しました。<br>・#{classroom.errors.full_messages.join('<br>・')}"
          redirect_to edit_using_class_classrooms_path(@school) and return
        else
          classroom.update_attributes(item)
          @school.update(first_edit: true)
        end
      end
    end
    flash[:success] = "クラス編集を更新しました。"
    redirect_to classrooms_path and return
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
    redirect_to edit_using_class_classrooms_path(@school)
  end


private

  # schoolの特定
  def set_school
    @school = current_school
  end

  def using_class_params
    params.require(:school).permit(classrooms: [:using_class, :class_name])[:classrooms]
  end
end
