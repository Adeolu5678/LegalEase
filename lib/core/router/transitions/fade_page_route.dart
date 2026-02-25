import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:legalease/core/theme/app_spacing.dart';

class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;

  FadePageRoute({
    required this.page,
    this.duration = AppAnimation.medium,
    super.settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
              child: child,
            );
          },
          transitionDuration: duration,
          reverseTransitionDuration: duration,
        );
}

class SlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final AxisDirection direction;
  final Duration duration;

  SlidePageRoute({
    required this.page,
    this.direction = AxisDirection.right,
    this.duration = AppAnimation.medium,
    super.settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            Offset begin;
            switch (direction) {
              case AxisDirection.up:
                begin = const Offset(0, 1);
                break;
              case AxisDirection.down:
                begin = const Offset(0, -1);
                break;
              case AxisDirection.left:
                begin = const Offset(1, 0);
                break;
              case AxisDirection.right:
                begin = const Offset(-1, 0);
                break;
            }

            return SlideTransition(
              position: Tween<Offset>(
                begin: begin,
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
          transitionDuration: duration,
          reverseTransitionDuration: duration,
        );
}

class ScalePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;

  ScalePageRoute({
    required this.page,
    this.duration = AppAnimation.medium,
    super.settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return ScaleTransition(
              scale: Tween<double>(
                begin: 0.9,
                end: 1.0,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                ),
                child: child,
              ),
            );
          },
          transitionDuration: duration,
          reverseTransitionDuration: duration,
        );
}

class FadeSlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;

  FadeSlidePageRoute({
    required this.page,
    this.duration = AppAnimation.medium,
    super.settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                ),
                child: child,
              ),
            );
          },
          transitionDuration: duration,
          reverseTransitionDuration: duration,
        );
}

CustomTransitionPage<T> buildFadeTransitionPage<T>({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ),
        child: child,
      );
    },
    transitionDuration: AppAnimation.medium,
    reverseTransitionDuration: AppAnimation.medium,
  );
}

CustomTransitionPage<T> buildSlideTransitionPage<T>({
  required GoRouterState state,
  required Widget child,
  AxisDirection direction = AxisDirection.right,
}) {
  Offset begin;
  switch (direction) {
    case AxisDirection.up:
      begin = const Offset(0, 0.1);
      break;
    case AxisDirection.down:
      begin = const Offset(0, -0.1);
      break;
    case AxisDirection.left:
      begin = const Offset(0.1, 0);
      break;
    case AxisDirection.right:
      begin = const Offset(-0.1, 0);
      break;
  }

  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: begin,
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        )),
        child: FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
          child: child,
        ),
      );
    },
    transitionDuration: AppAnimation.medium,
    reverseTransitionDuration: AppAnimation.medium,
  );
}
