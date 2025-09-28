// lib/logic/video/videos_bloc.dart

import 'package:eduzon/logic/video/videos_event.dart';
import 'package:eduzon/logic/video/videos_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/admin_repository.dart';

class VideosBloc extends Bloc<VideosEvent, VideosState> {
  final AdminRepository _adminRepository;

  VideosBloc(this._adminRepository) : super(VideosInitial()) {
    on<LoadVideos>(_onLoadVideos);
    on<AddVideo>(_onAddVideo);
    on<UpdateVideo>(_onUpdateVideo);
  }

  void _onLoadVideos(LoadVideos event, Emitter<VideosState> emit) async {
    emit(VideosLoading());
    try {
      final videos = await _adminRepository.getVideos(
        courseId: event.courseId,
        subjectId: event.subjectId,
        chapterId: event.chapterId,
      );
      emit(VideosLoaded(videos));
    } catch (e) {
      emit(VideosError(e.toString()));
    }
  }

  void _onAddVideo(AddVideo event, Emitter<VideosState> emit) async {
    try {
      await _adminRepository.addVideo(
        courseId: event.courseId,
        subjectId: event.subjectId,
        chapterId: event.chapterId,
        title: event.title,
        videoId: event.videoId,
        duration: event.duration,
      );
      add(LoadVideos(courseId: event.courseId, subjectId: event.subjectId, chapterId: event.chapterId));
    } catch (e) {
      emit(VideosError(e.toString()));
    }
  }

  void _onUpdateVideo(UpdateVideo event, Emitter<VideosState> emit) async {
    try {
      await _adminRepository.updateVideo(
        courseId: event.courseId,
        subjectId: event.subjectId,
        chapterId: event.chapterId,
        videoId: event.id,
        data: {
          'title': event.newTitle,
          'videoId': event.newVideoId,
          'duration': event.newDuration,
        },
      );
      add(LoadVideos(courseId: event.courseId, subjectId: event.subjectId, chapterId: event.chapterId));
    } catch (e) {
      emit(VideosError(e.toString()));
    }
  }
}