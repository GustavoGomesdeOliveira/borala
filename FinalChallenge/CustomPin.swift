import UIKit
import MapKit

class CustomPin: NSObject, MKAnnotation{
    var title: String?
    var coordinate: CLLocationCoordinate2D
    var pinImage: UIImage? = UIImage(named: "pizzapin")

    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
    
    
}
