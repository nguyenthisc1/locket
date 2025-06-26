import 'package:dartz/dartz.dart';
import 'package:locket/core/error/failures.dart';
import 'package:locket/core/services/dynamic_links_service.dart';
import 'package:locket/domain/auth/repositories/auth_firebase_repository.dart';

class EmailLinkSendUsecase {
  final AuthFirebaseRepository authFirebaseRepository;
  final DynamicLinksService _dynamicLinksService;

  EmailLinkSendUsecase(
    this.authFirebaseRepository, {
    DynamicLinksService? dynamicLinksService,
  }) : _dynamicLinksService = dynamicLinksService ?? DynamicLinksService();

  Future<Either<Failure, void>> call(String email) async {
    try {
      // Save email for later use with email link
      await _dynamicLinksService.saveEmailForLink(email);

      // Send email link
      return await authFirebaseRepository.sendEmailLink(email);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
