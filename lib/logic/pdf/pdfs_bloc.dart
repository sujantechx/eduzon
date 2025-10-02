// lib/logic/pdf/pdfs_bloc.dart

import 'package:eduzon/logic/pdf/pdfs_event.dart';
import 'package:eduzon/logic/pdf/pdfs_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/admin_repository.dart';

class PdfsBloc extends Bloc<PdfsEvent, PdfsState> {
  final AdminRepository _adminRepository;

  PdfsBloc(this._adminRepository) : super(PdfsInitial()) {
    on<LoadPdfs>(_onLoadPdfs);
    on<AddPdf>(_onAddPdf);
    on<UpdatePdf>(_onUpdatePdf);
  }

  void _onLoadPdfs(LoadPdfs event, Emitter<PdfsState> emit) async {
    emit(PdfsLoading());
    try {
      final pdfs = await _adminRepository.getPdfs(
        courseId: event.courseId,
        subjectId: event.subjectId,
        chapterId: event.chapterId,
      );
      emit(PdfsLoaded(pdfs));
    } catch (e) {
      emit(PdfsError(e.toString()));
    }
  }

  void _onAddPdf(AddPdf event, Emitter<PdfsState> emit) async {
    try {
      await _adminRepository.addPdf(
        courseId: event.courseId,
        subjectId: event.subjectId,
        chapterId: event.chapterId,
        title: event.title,
        url: event.url,
        pdfNumber: event.pdfNumber,
      );
      add(LoadPdfs(courseId: event.courseId, subjectId: event.subjectId, chapterId: event.chapterId));
    } catch (e) {
      emit(PdfsError(e.toString()));
    }
  }

  void _onUpdatePdf(UpdatePdf event, Emitter<PdfsState> emit) async {
    try {
      // 💡 Create the complete data map here.
      final Map<String, dynamic> updateData = {
        'title': event.newTitle,
        'url': event.newUrl,
        'pdfNumber': event.newPdfNumber,
      };

      await _adminRepository.updatePdf(
        courseId: event.courseId,
        subjectId: event.subjectId,
        chapterId: event.chapterId,
        pdfId: event.id,
        data: updateData,  // 💡 Pass the single, complete map.
      );
      add(LoadPdfs(courseId: event.courseId, subjectId: event.subjectId, chapterId: event.chapterId));
    } catch (e) {
      emit(PdfsError(e.toString()));
    }
  }}