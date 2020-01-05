import '../annotations.dart';

part 'view_model.g.dart';

@Route("/home/first")
@LivingString()
class ViewModel {
  @LivingString()
  String name = _$ViewModel;
}
