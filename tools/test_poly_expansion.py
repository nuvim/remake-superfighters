from test_full_sim import point_in_poly

poly_without_expansion = [(127, 255), (133, 255), (157, 273), (157, 335), (127, 335)]
poly_with_expansion = [(126.5, 254.5), (133.5, 254.5), (157.5, 272.5), (157.5, 335), (126.5, 335)]

print("Testing x=129.7, y=255.0:")
print("Without expansion:", point_in_poly(129.7, 255.0, poly_without_expansion))
print("With expansion (IncreaseCorners):", point_in_poly(129.7, 255.0, poly_with_expansion))
