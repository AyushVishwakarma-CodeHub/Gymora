package com.gymora.controller;

import com.gymora.model.dto.request.DietPlanRequest;
import com.gymora.model.dto.response.ApiResponse;
import com.gymora.model.dto.response.DietPlanResponse;
import com.gymora.service.DietPlanService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/diet-plans")
@RequiredArgsConstructor
@Tag(name = "Diet Plans", description = "Diet plan management endpoints")
public class DietPlanController {

    private final DietPlanService dietPlanService;

    @PostMapping
    @PreAuthorize("hasRole('TRAINER')")
    @Operation(summary = "Create diet plan")
    public ResponseEntity<ApiResponse<DietPlanResponse>> createPlan(
            @Valid @RequestBody DietPlanRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("Diet plan created", dietPlanService.createPlan(request)));
    }

    @GetMapping("/customer/{customerId}")
    @Operation(summary = "Get customer diet plans")
    public ResponseEntity<ApiResponse<List<DietPlanResponse>>> getCustomerPlans(
            @PathVariable Long customerId) {
        return ResponseEntity.ok(ApiResponse.success(dietPlanService.getCustomerPlans(customerId)));
    }

    @GetMapping("/customer/{customerId}/active")
    @Operation(summary = "Get active diet plans")
    public ResponseEntity<ApiResponse<List<DietPlanResponse>>> getActiveCustomerPlans(
            @PathVariable Long customerId) {
        return ResponseEntity.ok(ApiResponse.success(
                dietPlanService.getActiveCustomerPlans(customerId)));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('TRAINER')")
    @Operation(summary = "Update diet plan")
    public ResponseEntity<ApiResponse<DietPlanResponse>> updatePlan(
            @PathVariable Long id, @RequestBody DietPlanRequest request) {
        return ResponseEntity.ok(ApiResponse.success("Diet plan updated",
                dietPlanService.updatePlan(id, request)));
    }
}
