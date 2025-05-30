import SwiftUI

struct submitReportView: View {
    // State variables for the form inputs
    @State private var reportTitleInput: String = ""
    @State private var reportDescriptionInput: String = ""
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false


    // Environment variable to dismiss the view (for the back button)
    @Environment(\.dismiss) var dismiss

    // Properties passed to the view (as in your Kotlin composable)
    var token: String
    var id: Int
    // 'context' is not directly used in SwiftUI in the same way as Android.
    // For Toast-like messages, you'd use Alerts or custom overlays.
     var body: some View {
        VStack {
            TopAppBar()
            VStack { // Main vertical stack for all content
                Spacer()
        
                // ScrollView for the form content in case it overflows
                VStack(alignment: .leading, spacing: 8) { // Content of the white rounded box
                    // Back Arrow
                    Image(systemName: "arrow.backward") // SF Symbol for back arrow
                        // If you have "baseline_arrow_back_24" in assets: Image("baseline_arrow_back_24")
                        .font(.title2) // Adjust size as needed
                        .foregroundColor(.black) // Or a specific color
                        .onTapGesture {
                            // Navigate back to the HomePage (equivalent)
                            print("Back arrow tapped - dismissing view")
                            dismiss()
                        }

                    // "Report an Issue" Title
                    Text("Report an Issue")
                        .font(.system(size: 24, weight: .bold))
                        .frame(maxWidth: .infinity, alignment: .center) // To center it

                    // Title field
                    Text("Title:")
                        .font(.system(size: 16, weight: .semibold))
                    TextField("Enter title", text: $reportTitleInput)
                        .padding(10) // Inner padding for text field text
                        .background(Color(white: 0.784)) // containerColor
                        .cornerRadius(5) // Standard corner radius for text fields
                        // .textFieldStyle(PlainTextFieldStyle()) // Can be used for more control

                    // Description field
                    Text("Description:")
                        .font(.system(size: 16, weight: .semibold))
                    // Use TextEditor for multi-line input
                    TextEditor(text: $reportDescriptionInput)
                        .frame(minHeight: 40, idealHeight: 50, maxHeight: 100) // Adjust height
                        .padding(2) // Inner padding for TextEditor
                        .background(Color(white: 0.784)) // containerColor
                        .cornerRadius(5)
                        .overlay( // Optional: add a border like many text editors
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    // Image Upload Field
                      Text("Upload Image:")
                          .font(.system(size: 16, weight: .semibold))
                      
                      Button(action: {
                          showImagePicker = true
                      }) {
                          if let selectedImage = selectedImage {
                              Image(uiImage: selectedImage)
                                  .resizable()
                                  .scaledToFit()
                                  .frame(height: 100)
                                  .cornerRadius(5)
                          } else {
                              ZStack() {
                                  Color(white: 0.784)
                                      .frame(height: 100)
                                      .cornerRadius(5)
                                  VStack {
                                      Image(systemName: "photo.on.rectangle")
                                          .font(.system(size: 32))
                                          .foregroundColor(.gray)
                                      Text("Tap to select an image")
                                          .foregroundColor(.gray)
                                      
                                  }
                                
                              }
                              .padding(.bottom)
                          }
                          
                      }
                    

                    // Log.d("id", "id:${id}") - Can be printed on appear or button tap
                    // For example, print it when the button is tapped:

                    // Submit Button
                    Button(action: {
                        print("Submit Report Button Tapped")
                        print("ID: \(id)")
                        print("Token: \(token)")
                        print("Title: \(reportTitleInput)")
                        print("Description: \(reportDescriptionInput)")
                        // Here you would typically call a ViewModel function
                        // For now, we just print.
                        // reportViewModel.createReport(token, id, navController)
                    }) {
                        Text("Submit Report")
                            .foregroundColor(.white)
                            .fontWeight(.semibold) // Or .medium
                            .frame(maxWidth: .infinity) // To make button full width
                            .padding() // Padding inside the button
                            .background(Color(red: 1.0, green: 0.627, blue: 0.004)) // Orange button color
                            .cornerRadius(8)
                    }
                }
                .padding()
                .background(.white) // Background of the form container
                .cornerRadius(16)        // R ounded corners for the form container
                .padding(.horizontal, 40)
                .padding(.vertical, 32)
                
                Spacer() // Pushes BotAppBar to the bottom
            }
            BotAppBar()
        }
        .background(
            Image("backgroundparking") // Ensure "backgroundparking" is in your Assets.xcassets
                .resizable()
                .overlay(Color.black.opacity(0.5))
                .scaledToFill() // Equivalent to ContentScale.Crop
            )
        .navigationBarHidden(true) // Hides the default navigation bar if this view is in a NavigationStack
        // .navigationBarBackButtonHidden(true) // If you want to rely solely on your custom back button
        .onAppear {
            print("submitReportView appeared. ID: \(id), Token: \(token)")
        }
    }
}

// --- Preview ---
#Preview {
    // Wrap in NavigationStack for the @Environment(\.dismiss) to work in preview
    // and to mimic typical app structure.
    NavigationStack {
        submitReportView(token: "PREVIEW_TOKEN", id: 123)
    }
}
