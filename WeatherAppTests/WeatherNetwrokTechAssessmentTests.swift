import XCTest
import Network
@testable import WeatherApp

class WeatherNetwrokTechAssessmentTests: XCTestCase {
  // test the imageList
  func testPhotosList() {
    let photoGallery = PhotoGalleryView()
    XCTAssertNotNil(photoGallery.images)
    XCTAssertEqual(photoGallery.images.count , 10)
    photoGallery.imageName = "IMG1"
    photoGallery.goToDetailView = false
    XCTAssertFalse(photoGallery.goToDetailView)
  }

}


