//
//  MKMapView+Rx.swift
//  Pods
//
//  Created by indy on 2016. 10. 17..
//
//

import Foundation
import UIKit
import MapKit
import RxCocoa
import RxSwift


// MKMapViewDelegate

extension Reactive where Base: MKMapView {
    
    /**
     Reactive wrapper for `delegate`.
     
     For more information take a look at `DelegateProxyType` protocol documentation.
     */
    public var delegate: RxMKMapViewDelegateProxy {
        return RxMKMapViewDelegateProxy.proxyForObject(base)
    }

    /**
     Installs delegate as forwarding delegate on `delegate`.
     Delegate won't be retained.
     
     It enables using normal delegate mechanism with reactive delegate mechanism.
     
     - parameter delegate: Delegate object.
     - returns: Disposable object that can be used to unbind the delegate.
     */
    public func setDelegate(_ delegate: MKMapViewDelegate)
        -> Disposable {
            return RxMKMapViewDelegateProxy.installForwardDelegate(delegate, retainDelegate: false, onProxyForObject: base)
    }
}

extension Reactive where Base: MKMapView {

    public func handleViewForAnnotation(_ closure: RxMKHandleViewForAnnotaion?) {
        delegate.handleViewForAnnotation = closure
    }

}

extension Reactive where Base: MKMapView {
    
    private func methodInvokedWithParam1<T>(_ selector: Selector) -> Observable<T> {
        return delegate
            .methodInvoked(selector)
            .map { a in return try castOrThrow(T.self, a[1]) }
    }
    
    private func controlEventWithParam1<T>(_ selector: Selector) -> ControlEvent<T> {
        return ControlEvent(events: methodInvokedWithParam1(selector))
    }
    
    /**
     Wrapper of: func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool)
     */
    public var regionWillChange: ControlEvent<RxMKAnimatedProperty> {
        return ControlEvent(events:
            methodInvokedWithParam1(#selector(MKMapViewDelegate.mapView(_:regionWillChangeAnimated:)))
                .map(RxMKAnimatedProperty.init)
        )
    }
    
    /**
     Wrapper of: func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool)
     */
    public var regionDidChange: ControlEvent<RxMKAnimatedProperty> {
        return ControlEvent(events:
            methodInvokedWithParam1(#selector(MKMapViewDelegate.mapView(_:regionDidChangeAnimated:)))
                .map(RxMKAnimatedProperty.init)
        )
    }
    
    /**
     Wrapper of: func mapViewWillStartLoadingMap(_ mapView: MKMapView)
     */
    public var willStartLoadingMap: ControlEvent<Void> {
        return ControlEvent(events:
            delegate.methodInvoked(#selector(MKMapViewDelegate.mapViewWillStartLoadingMap(_:)))
                .map { _ in return }
        )
    }
    
    /**
     Wrapper of: func mapViewDidFinishLoadingMap(_ mapView: MKMapView)
     */
    public var didFinishLoadingMap: ControlEvent<Void> {
        return ControlEvent(events:
            delegate.methodInvoked(#selector(MKMapViewDelegate.mapViewDidFinishLoadingMap(_:)))
                .map { _ in return }
        )
    }
    
    /**
     Wrapper of: func mapViewDidFailLoadingMap(_ mapView: MKMapView, withError error: Error)
     */
    public var didFailLoadingMap: ControlEvent<Void> {
        return controlEventWithParam1(#selector(MKMapViewDelegate.mapViewDidFailLoadingMap(_:withError:)))
    }
    
    /**
     Wrapper of: func mapViewWillStartRenderingMap(_ mapView: MKMapView)
     */
    public var willStartRenderingMap: ControlEvent<Void> {
        return ControlEvent(events:
            delegate.methodInvoked(#selector(MKMapViewDelegate.mapViewWillStartRenderingMap(_:)))
                .map { _ in return }
        )
    }
    
    /**
     Wrapper of: func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool)
     */
    public var didFinishRenderingMap: ControlEvent<RxMKRenderingProperty> {
        return ControlEvent(events:
            methodInvokedWithParam1(#selector(MKMapViewDelegate.mapViewDidFinishRenderingMap(_:fullyRendered:)))
                .map(RxMKRenderingProperty.init)
        )
    }

    /**
     Wrapper of: func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView])
     */
    public var didAddAnnotationViews: ControlEvent<[MKAnnotationView]> {
        return ControlEvent(events:
            methodInvokedWithParam1(#selector(
                MKMapViewDelegate.mapView(_:didAdd:)!
                    as (MKMapViewDelegate) -> (MKMapView, [MKAnnotationView]) -> Void))
        )
    }
    
    /**
     Wrapper of: func mapViewDidFailLoadingMap(_ mapView: MKMapView, didSelect view: MKAnnotationView)
     */
    public var didSelectAnnotationView: ControlEvent<MKAnnotationView> {
        return controlEventWithParam1(#selector(MKMapViewDelegate.mapView(_:didSelect:)))
    }
    
    /**
     Wrapper of: func mapViewDidFailLoadingMap(_ mapView: MKMapView, didDeselect view: MKAnnotationView)
     */
    public var didDeselectAnnotationView: ControlEvent<MKAnnotationView> {
        return controlEventWithParam1(#selector(MKMapViewDelegate.mapView(_:didDeselect:)))
    }


}

public struct RxMKAnimatedProperty {
    public let isAnimated: Bool
}

public struct RxMKRenderingProperty {
    public let isFullyRendered: Bool
}