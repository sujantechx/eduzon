// lib/presentation/blocs/pdfs/pdfs_state.dart

import 'package:equatable/equatable.dart';

import '../../data/models/pdf_model.dart';

abstract class PdfsState extends Equatable {
  const PdfsState();
  @override
  List<Object> get props => [];
}

class PdfsInitial extends PdfsState {}
class PdfsLoading extends PdfsState {}
class PdfsLoaded extends PdfsState {
  final List<PdfModel> pdfs;
  const PdfsLoaded(this.pdfs);
  @override
  List<Object> get props => [pdfs];
}
class PdfsError extends PdfsState {
  final String message;
  const PdfsError(this.message);
  @override
  List<Object> get props => [message];
}