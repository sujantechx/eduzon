// lib/presentation/blocs/videos/videos_state.dart


import 'package:equatable/equatable.dart';

import '../../data/models/video_model.dart';

abstract class VideosState extends Equatable {
  const VideosState();
  @override
  List<Object> get props => [];
}

class VideosInitial extends VideosState {}
class VideosLoading extends VideosState {}
class VideosLoaded extends VideosState {
  final List<VideoModel> videos;
  const VideosLoaded(this.videos);
  @override
  List<Object> get props => [videos];
}
class VideosError extends VideosState {
  final String message;
  const VideosError(this.message);
  @override
  List<Object> get props => [message];
}