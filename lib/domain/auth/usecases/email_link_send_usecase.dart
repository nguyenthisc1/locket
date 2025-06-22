import 'package:dartz/dartz.dart';
import 'package:locket/core/error/failures.dart';
import 'package:locket/core/services/dynamic_links_service.dart';
import 'package:locket/domain/auth/repositories/auth_repository.dart';

class EmailLinkSendUsecase {
  final AuthRepository authRepository;
  final DynamicLinksService _dynamicLinksService;

  EmailLinkSendUsecase(
    this.authRepository, {
    DynamicLinksService? dynamicLinksService,
  }) : _dynamicLinksService = dynamicLinksService ?? DynamicLinksService();

  Future<Either<Failure, void>> call(String email) async {
    try {
      // Save email for later use with email link
      await _dynamicLinksService.saveEmailForLink(email);

      // Send email link
      return await authRepository.sendEmailLink(email);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
