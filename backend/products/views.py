from rest_framework import generics
from .models import Product
from .serializers import ProductSerializer
from django.shortcuts import render

class ProductListAPIView(generics.ListAPIView):
    queryset = Product.objects.all()
    serializer_class = ProductSerializer

# def manage_products(request):
#     return render(request, "products/product_list.html")
