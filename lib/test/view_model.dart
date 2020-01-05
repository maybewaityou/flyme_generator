import '../annotations.dart';

part 'view_model.g.dart';

@Route("/home/first")
@LivingString()
class ViewModel {
  @LivingString()
  // TODO: 注解不能修饰属性 ?
  String name = _$ViewModel;
}
